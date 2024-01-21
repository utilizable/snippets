```sh
#-----------------------------------------------------------------------------
#    invokePipeline.sh
#    Purpose: example how to trigger pipeline using cli
#
#    @author 
#    @version 0.1 - 24/10/23
#-----------------------------------------------------------------------------
#!/bin/bash

# main function
function main() {
  user_access_token="${1}"
  project_id="${2}"
  project_ref="${3}"
  
  getSingleProject "${user_access_token}" "${project_id}"
  if [ $? -eq 0 ]; then
      echo "ERROR: project not exists! ~ ${project_id}"; exit 1
  fi

 listRepositoryTags       \
   "${user_access_token}" \
   "${project_id}"        |
    jq -rc '
        . 
        | .[] 
        | select( .name | match ( "'"${project_ref}"'$" ) ) 
        | .name
    '
    
  if [ $? -eq 0 ]; then
      echo "ERROR: ref no exists in given project! ~ ${project_id}"; exit 1
  fi

  trigger_token="$(
    listRepositoryTriggerTokens \
      "${user_access_token}"    \ 
      "${project_id}"           |
      jq -rc '
        map(
          select(
            .description 
            | test( "'"${CI_PROJECT_NAME}"'$" )
            ) 
          | select( 
            .owner.username 
            | test( "'"${GITLAB_USER_NAME}"'" )
          )
        ) | first'
      '
  )";

  if [ "${trigger_token}" == "null" ]; then
    trigger_token="$(
      createTriggerToken       \
        "${user_access_token}" \
        "${project_id}"        \
        "${project_ref}"   
    )";
  fi

  newPipeline="$(
    createNewPipeline    \
      "${trigger_token}" \
      "${project_id}"    \
      "${project_ref}"
  )";

  newPipelineId="$(
    jq -rc '
      .id
    ' <<< "${newPipeline}"
  )"

  if [[ ${newPipeline}  =~ [^0-9]+$ ]]; then
     echo "ERROR: problem during pipeline execution! ~ ${newPipeline}"; exit 1
  fi
  
  newPipelineUrl="$(
    jq -rc '
      .web_url
    ' <<< "${newPipeline}"
  )";
  
  echo "SUCCESS: succesfully triggered new pipeline! ~ ${newPipelineUrl}";
};

#-----------------------------------------------------------------------------
# listTotalPages - list total x-pages for given rest endpoint

function listTotalPages() {
  local user_access_token="${1}"
  local gitlab_endpoint="${2}"  
  
  curl                                             \
    --fail                                         \
    --silent                                       \
    --head                                         \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request GET -G                               \
    --url "${gitlab_endpoint}"                     |
    sed '/x-total-pages/!d'                        |
    sed 's/[^[:digit:]]//g'                                                           
};

#-----------------------------------------------------------------------------
# getSingleProject - get basic information about project

function getSingleProject() {
  local user_access_token="${1}"
  local project_id="${2}"  

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}"
  );

  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request POST                                 \
    --form description="${CI_PROJECT_NAME}"        \
    --url "${gitlab_endpoint}"                                                 
};

#-----------------------------------------------------------------------------
# listRepositoryTags - list repository tags

function listRepositoryTags() {
  local user_access_token="${1}"
  local project_id="${2}"  

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/repository/tags"
  );
  
  local total_pages="$(listTotalPages ${user_access_token} ${gitlab_endpoint})"
  local output
  
  for page in $(seq 1 $total_pages); do
    output+="$(
      curl                                           \
      --fail                                         \
      --silent                                       \
      --header "PRIVATE-TOKEN: ${user_access_token}" \
      --request GET -G                               \
      --url "${gitlab_endpoint}"                     \
      --data "page=${page}"
    )";
  done

  echo "${output}"
};

#-----------------------------------------------------------------------------
# listRepositoryTriggerTokens - list repository tirgger tokens 

function listRepositoryTriggerTokens() {
  local user_access_token="${1}"
  local project_id="${2}"  

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/triggers"
  );
  
  local total_pages="$(listTotalPages ${user_access_token} ${gitlab_endpoint})"
  local output
  
  for page in $(seq 1 $total_pages); do
    output+="$(
      curl                                             \
        --fail                                         \
        --silent                                       \
        --header "PRIVATE-TOKEN: ${user_access_token}" \
        --request GET -G                               \
        --url "${gitlab_endpoint}"                     \
        --data "page=${page}"
    )";
  done

  echo "${output}"
};

#-----------------------------------------------------------------------------
# createTriggerToken - create trigger token for given project

function createTriggerToken() {
  local user_access_token="${1}"
  local project_id="${2}"  
  local project_ref="${3:HEAD}"

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/triggers"
  );

  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request POST                                 \
    --form description="${CI_PROJECT_NAME}"        \
    --url "${gitlab_endpoint}"                                                 
};

#-----------------------------------------------------------------------------
# createNewPipeline - create pipeline in target project on given reference ( tag / branch ) 

function createNewPipeline() {
  local pipeline_trigger_token="${1}"
  local project_id="${2}"  
  local project_ref="${3:HEAD}"

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/repository/branches"
  );

  curl        
    --fail                                   \
    --silent                                 \
    --request POST                           \
    --form "token=${pipeline_trigger_token}" \
    --form "ref=${project_ref}"              \
    --url "${gitlab_endpoint}"   
};

#-----------------------------------------------------------------------------
main $@
```
